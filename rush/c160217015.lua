--髑巌襲来
--Skullcrag Incursion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send to the Graveyard and Fusion Summon
	local params = {s.filter,s.mfilter,s.fextra,Fusion.ShuffleMaterial}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsDefense(0)
end
function s.mfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_GRAVE|LOCATION_MZONE) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCountRush(Card.IsNotMaximumModeSide,tp,LOCATION_MZONE,LOCATION_MZONE,nil)>=3
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #dg>0 end
end
function s.operation(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		--Effect
		local dg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
		if #dg>0 then
			local sg=dg:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			if Duel.Destroy(sg,REASON_EFFECT)>0 and fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				fusop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end