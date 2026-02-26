--蒼救の祈誓
--Skysavior Oath
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Skysavior" in the hand or Graveyard
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e0:SetValue(160012052)
	c:RegisterEffect(e0)
	--Activate
	Fusion.RegisterSummonEff(c,aux.FilterBoolFunction(s.fusfilter),nil,function(e,tp,mg) return nil,s.fcheck end)
end
function s.fusfilter(c)
	return c:IsRace(RACE_CELESTIALWARRIOR)
end
function s.matfilter1(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_WARRIOR)
end
function s.matfilter2(c)
	return c:IsType(TYPE_EFFECT) and c:IsRace(RACE_FAIRY)
end
function s.fcheck(tp,sg,fc)
	local mg1=sg:Filter(s.matfilter1,nil)
	local mg2=sg:Filter(s.matfilter2,nil)
	return #sg>1 and #mg1==1 and #mg2>0
end