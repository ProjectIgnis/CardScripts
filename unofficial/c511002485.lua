--幻奏の歌姫ソプラノ (Anime)
--Soprano the Melodious Songstress (Anime)
--Rescripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--perform a fusion summon
	local params = {nil,nil,nil,nil,Fusion.ForcedHandler}
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
end