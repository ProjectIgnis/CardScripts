--髑髏の司祭ヤスシ
--Yasushi the Skull Knight
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,80604091,78010363)
	aux.GlobalCheck(s,function()
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD)
		ge2:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		ge2:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
		ge2:SetTarget(s.mttg)
		ge2:SetValue(s.mtval)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_names={80604091,78010363}
s.illegal=true
function s.mttg(e,c)
	return c:IsCode(80604091) and not c:IsMonster()
end
function s.mtval(e,c)
	if not c then return false end
	return c:IsOriginalCode(id)
end