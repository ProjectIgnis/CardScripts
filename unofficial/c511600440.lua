--平行世界融合 (Manga)
--Parallel World Fusion (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,aux.FALSE,nil,Fusion.ShuffleMaterial)
	c:RegisterEffect(e1)
end
