--面子蝙蝠
--Bettan Bat
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Change the position of opponent's Normal or Special Summoned monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(3)
	e1:SetCondition(function(e,tp,eg) return not eg:IsContains(e:GetHandler()) and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Change position of a monster if it is flipped face-up or face-down
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.postg2)
	e3:SetOperation(s.posop2)
	c:RegisterEffect(e3)
end
s.toss_coin=true
function s.posfilter(c,e,tp)
	return (c:IsCanTurnSet() or (not c:IsAttackPos() and c:IsCanChangePosition())) and c:IsCanBeEffectTarget(e) and c:IsSummonPlayer(1-tp)
		and c:IsLocation(LOCATION_MZONE)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.posfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.posfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=eg:FilterSelect(tp,s.posfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,tp,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local coin=Duel.TossCoin(tp,1)
	local pos=coin==COIN_HEADS and POS_FACEUP_ATTACK or POS_FACEDOWN_DEFENSE
	Duel.ChangePosition(tc,pos)
end
function s.posfilter2(c,e)
	return (c:IsCanTurnSet() or not c:IsPosition(POS_FACEUP_ATTACK)) and c:IsCanBeEffectTarget(e) and c:IsCanChangePosition()
		and ((c:IsPosition(POS_FACEUP) and c:IsPreviousPosition(POS_FACEDOWN))
		or (c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsPreviousPosition(POS_FACEUP)))
end
function s.postg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and chkc:IsLocation(LOCATION_MZONE) and s.posfilter2(chkc,e) end
	if chk==0 then return eg:IsExists(s.posfilter2,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=eg:FilterSelect(tp,s.posfilter2,1,1,nil,e)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,tp,0)
end
function s.posop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local opt=0
	if (tc:IsPosition(POS_FACEDOWN) or tc:IsType(TYPE_TOKEN)) then
		opt=POS_FACEUP_ATTACK
	elseif tc:IsPosition(POS_FACEUP_ATTACK) then
		opt=POS_FACEDOWN_DEFENSE
	elseif tc:IsPosition(POS_FACEUP_DEFENSE) then
		opt=POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE
	end
	if opt==0 then return end
	local pos=Duel.SelectPosition(tp,tc,opt)
	if pos==0 then return end
	Duel.ChangePosition(tc,pos)
end