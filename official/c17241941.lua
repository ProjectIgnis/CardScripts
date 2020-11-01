--ダイカミナリ・ジャイクロプス
--Daikaminari Gyclops
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Enable pendulum summon
	Pendulum.AddProcedure(c)
	--Banish itself if used as synchro material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetCondition(s.rmcon)
	c:RegisterEffect(e1)
	--If normal summoned, change its battle position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	--Destroy 1 face-up spell/trap on the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--Return 1 card in your pendulum zone to hand
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+2)
	e4:SetCondition(s.sendcon)
	e4:SetTarget(s.sendtg)
	e4:SetOperation(s.sendop)
	c:RegisterEffect(e4)
end
	--Check if special summoned from extra deck
function s.rmcon(e)
	local c=e:GetHandler()
	return c:IsSummonLocation(LOCATION_EXTRA)
		and (c:GetReason()&REASON_MATERIAL+REASON_SYNCHRO)==REASON_MATERIAL+REASON_SYNCHRO
end
	--Change its battle position
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
	--Activation legality
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
	--Destroy 1 face-up spell/trap on the field
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
	--If destroyed in the pendulum zone
function s.sendcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_PZONE)
end
	--Activation legality
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0 end
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
	--Return 1 card in your pendulum zone to hand
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0):Select(tp,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.HintSelection(g)
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end