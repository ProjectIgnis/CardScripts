--冥跡祭－イシリアの降霊－
--Monumenthes Festival -The Isyria Seance-
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local ritfilter={handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup}
	local e1=Ritual.CreateProc(ritfilter)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation(Ritual.Operation(ritfilter)))
	c:RegisterEffect(e1)
end
s.listed_names={160024037,160024008}
function s.ritualfil(c)
	return c:IsCode(160024037)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsCode(160024008) and c:IsFaceup()
end
function s.cfilter(c,code)
	return c:IsCode(code) and (c:IsLocation(LOCATION_HAND) or c:IsFacedown()) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil,160024047) 
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil,160024048) 
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil,160024061) 
	end
end
function s.operation(ritop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		--Requirement
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil,160024047)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil,160024048)
		g:Merge(g2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g3=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil,160024061)
		g:Merge(g3)
		if Duel.SendtoGrave(g,REASON_COST)<1 then return end
		--Effect
		ritop(e,tp,eg,ep,ev,re,r,rp)
	end
end