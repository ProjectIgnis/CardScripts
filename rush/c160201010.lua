--オジギプス
--Bonded Bowing
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.drwcon)
	e1:SetTarget(s.drwtg)
	e1:SetOperation(s.drwop)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_WARRIOR) and c:IsAttackPos() and c:IsCanChangePositionRush()
end
function s.drwcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,0)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 and Duel.ChangePosition(g,POS_FACEUP_DEFENSE)==#g then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
