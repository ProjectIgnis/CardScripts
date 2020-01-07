--Cross Draw of Destiny
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc1=Duel.GetDecktopGroup(tp,1):GetFirst()
	local tc2=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	if tc1 and tc2 then
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.Draw(1-tp,1,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc1)
		Duel.ConfirmCards(tp,tc2)
		if tc1:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			Duel.BreakEffect()
			Duel.SpecialSummon(tc1,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
			Duel.Recover(tp,tc1:GetAttack(),REASON_EFFECT)
		else
			Duel.ShuffleHand(tp)
		end
		if tc2:IsCanBeSpecialSummoned(e,0,1-tp,false,false) then
			Duel.BreakEffect()
			Duel.SpecialSummon(tc2,0,1-tp,tp,false,false,POS_FACEUP_DEFENSE)
			Duel.Recover(1-tp,tc2:GetAttack(),REASON_EFFECT)
		else
			Duel.ShuffleHand(1-tp)
		end
	end
end
