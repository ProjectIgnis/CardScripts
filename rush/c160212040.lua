--虚鋼演機急転
--Imaginary Arc Turnover
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	local e1=Fusion.CreateSummonEff(c,s.fusfilter,s.matfilter,s.fextra,Fusion.ShuffleMaterial,nil,s.stage2)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.fusfilter(c)
	return c:IsRace(RACE_CYBORG)
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_GRAVE|LOCATION_MZONE) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and not c:IsMaximumModeSide()
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		if Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
			dg=dg:AddMaximumCheck()
			Duel.HintSelection(dg)
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end