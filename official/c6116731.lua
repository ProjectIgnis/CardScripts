--ムカデの進軍
--Swarm of Centipedes
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Change the position of another monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FLIP)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--Change itself to face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.selfpostg)
	e2:SetOperation(s.selfposop)
	c:RegisterEffect(e2)
end
function s.posfilter(c)
	return c:IsCanTurnSet() or not c:IsPosition(POS_FACEUP_ATTACK)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,tp,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
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
function s.selfpostg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and not c:HasFlagEffect(id) end
	c:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET)|RESET_PHASE|PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,tp,0)
end
function s.selfposop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end