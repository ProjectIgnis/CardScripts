--獣機界賢者ローラー・スタッグ
--Beast Gear Sage Roller Stag
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Change opponent's monsters to defense position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.poscond)
	e1:SetCost(s.poscost)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
end
s.listed_names={160002039,160004060}
function s.poscond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,700) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsCanChangePositionRush()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWNDEFENSE)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsCode(160002039,160004060)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	 Duel.PayLPCost(tp,700)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.ChangePosition(g:GetFirst(),POS_FACEUP_DEFENSE)>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			if #tg>0 then
				Duel.HintSelection(tg)
				Duel.BreakEffect()
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
			end
		end
	end
end