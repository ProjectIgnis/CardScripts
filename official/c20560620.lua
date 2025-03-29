--お代狸様の代算様ー
--Emperor Tanuki's Critter Count
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Tributed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	--Can send 1 monster from your Extra Deck to the GY to Ritual Summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTargetRange(LOCATION_EXTRA,0)
	e3:SetCondition(function(e) return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0 end)
	e3:SetTarget(s.mttg)
	e3:SetValue(1)
	e3:SetLabelObject({s.forced_replacement})
	c:RegisterEffect(e3)
end
function s.mttg(e,c)
	local g=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_EXTRA,0,nil)
	return g:IsContains(c)
end
function s.forced_replacement(e,tp,sg,rc)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
	return ct<=1,ct>1
end