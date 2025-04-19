--苦渋の決断
--Arduous Decision
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp) and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,2,REASON_EFFECT)>0 then
		local g=Duel.GetOperatedGroup()
		local rcard=g:GetFirst()
		local lcard=g:GetNext()
		local op=Duel.SelectOption(1-tp,aux.Stringid(id,1),aux.Stringid(id,2))
		if op==0 then
			Duel.ConfirmCards(1-tp,lcard)
			if lcard:IsMonster() and lcard:IsCanBeSpecialSummoned(e,0,tp,true,false) then
				Duel.BreakEffect()
				Duel.SpecialSummon(lcard,0,tp,tp,true,false,POS_FACEUP)
				Duel.SendtoGrave(rcard,REASON_EFFECT)
			else
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		elseif op==1 then
			Duel.ConfirmCards(1-tp,rcard)
			if rcard:IsMonster() and rcard:IsCanBeSpecialSummoned(e,0,tp,true,false) then
				Duel.BreakEffect()
				Duel.SpecialSummon(rcard,0,tp,tp,true,false,POS_FACEUP)
				Duel.SendtoGrave(lcard,REASON_EFFECT)
			else
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end