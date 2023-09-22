-- The height map functionality for Procedural Planet Generation

function Polyhedron:heightmapNoise(seed, minHeight, maxHeight)
	local centers = self:Centers()
	for i, v in ipairs(self.Faces) do
		--if #self.Faces[i] == 6 then
			local newFace = self.Faces[i]
			local range = maxHeight - minHeight
			local noiseMax = range/2
			local rangeAdjustment = maxHeight - noiseMax
			local frequency = 0.015

			local randomHeight =
				Round(
					ridgeNoise(
						frequency * (centers[i].x + seed),
						frequency * (centers[i].y + seed),
						frequency * (centers[i].z + seed))
					* noiseMax
					+ rangeAdjustment,
					(maxHeight-minHeight) / 3)
			--randomHeight = math.clamp(randomHeight,0,maxHeight)
			randomHeight = math.floor((randomHeight / 5 + 0.5) * 5)
			for j, vidx in pairs(newFace) do
				local radius = (self.Vertices[vidx] - self.Position).Magnitude
				self.Height = randomHeight
				local vertex = self.Position + (self.Vertices[vidx] - self.Position).Unit * (radius + randomHeight)--self.Position + (self.Vertices[vidx] - self.Position).Unit * (10 + randomHeight)
				self.Vertices[#self.Vertices+1] = vertex
				newFace[j] = #self.Vertices
			end
			self.Faces[i] = newFace
		--end
	end
end
