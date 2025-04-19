--ダーク・サンクチュアリ
--Dark Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	c:RegisterEffect(e4)
	--
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e5:SetCountLimit(1)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_EQUIP)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(id)
	e6:SetCondition(s.eqcon)
	e6:SetTarget(s.eqtg)
	e6:SetOperation(s.operation)
	c:RegisterEffect(e6)
	--destroy
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_ATTACK_ANNOUNCE)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCondition(s.atkcon)
	e7:SetTarget(s.atktg)
	e7:SetOperation(s.atkop)
	c:RegisterEffect(e7)
	--move
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e8:SetCode(EFFECT_SPSUMMON_PROC_G)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCondition(s.movecon)
	e8:SetOperation(s.moveop)
	c:RegisterEffect(e8)
	--copy
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e9:SetCode(EVENT_ADJUST)
	e9:SetRange(LOCATION_FZONE)
	e9:SetOperation(s.activ)
	c:RegisterEffect(e9)
	--maintain
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e10:SetCode(EVENT_PHASE+PHASE_END)
	e10:SetRange(LOCATION_FZONE)
	e10:SetCountLimit(1)
	e10:SetCondition(s.mtcon)
	e10:SetOperation(s.mtop)
	c:RegisterEffect(e10)
end
s.listed_names={CARD_DESTINY_BOARD,31829185}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsCode,1,nil,31829185)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	if c:IsLocation(LOCATION_FZONE) and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,31829185) and Duel.SelectEffectYesNo(tp,c) then
		e:SetCategory(CATEGORY_EQUIP)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
		e:SetOperation(s.operation)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if tc then
			Duel.Equip(tp,c,tc)
			--equip limit
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			c:RegisterEffect(e1)
			--end
			local e2=Effect.CreateEffect(c)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IMMEDIATELY_APPLY)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetRange(LOCATION_FZONE)
			e2:SetCountLimit(1)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetOperation(s.op)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			c:RegisterEffect(e2)
			c:RegisterFlagEffect(511000118,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SendtoDeck(c,nil,-2,REASON_EFFECT)
	Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseSingleEvent(e:GetHandler(),id,e,0,tp,tp,0)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,31829185)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and Duel.GetAttacker()==tc and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,31829185)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local a=Duel.GetAttacker()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,a:GetAttack()/2)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,a:GetAttack()/2)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local tc=e:GetHandler():GetEquipTarget()
	if not a or not tc or a~=tc then return end
	Duel.NegateAttack()
	local atk=a:GetAttack()
	local val=Duel.Damage(1-tp,atk/2,REASON_EFFECT)
	if val>0 then
		Duel.Recover(tp,val,REASON_EFFECT)
	end
end
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,31829185)
		and e:GetHandler():GetFlagEffect(511000118)==0
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckReleaseGroup(tp,nil,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
		Duel.Release(sg,REASON_COST)
	else
		Duel.Destroy(e:GetHandler(),REASON_RULE)
	end
end
function s.mvfilter(c,tp)
	if c:IsFacedown() or not c:IsCode(31893528,67287533,94772232,30170981) then return false end
	if c:IsLocation(LOCATION_MZONE) then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	else
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
function s.movecon(e,c,og)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(s.mvfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil,c:GetControler())
end
function s.moveop(e,tp,eg,ep,ev,re,r,rp,c,og)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.mvfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp):GetFirst()
	if tc then
		if tc:IsLocation(LOCATION_MZONE) then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		else
			Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
			--immune
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_IMMUNE_EFFECT)
			e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e4:SetRange(LOCATION_MZONE)
			e4:SetValue(s.efilter)
			e4:SetReset(RESET_EVENT|RESET_TOGRAVE|RESET_REMOVE|RESET_TEMP_REMOVE|RESET_TOHAND|RESET_TODECK|RESET_OVERLAY)
			tc:RegisterEffect(e4,true)
			--cannot be battle target
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
			e2:SetValue(aux.imval1)
			e2:SetReset(RESET_EVENT|RESET_TOGRAVE|RESET_REMOVE|RESET_TEMP_REMOVE|RESET_TOHAND|RESET_TODECK|RESET_OVERLAY)
			tc:RegisterEffect(e2,true)
			--Direct attack
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_DIRECT_ATTACK)
			e3:SetRange(LOCATION_MZONE)
			e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e3:SetTarget(s.dirtg)
			e3:SetReset(RESET_EVENT|RESET_TOGRAVE|RESET_REMOVE|RESET_TEMP_REMOVE|RESET_TOHAND|RESET_TODECK|RESET_OVERLAY)
			tc:RegisterEffect(e3,true)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT|RESET_TOGRAVE|RESET_REMOVE|RESET_TEMP_REMOVE|RESET_TOHAND|RESET_TODECK|RESET_OVERLAY)
			tc:RegisterEffect(e1,true)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
		end
	end
	return
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return tc~=e:GetOwner() and not tc:IsCode(CARD_DESTINY_BOARD)
end
function s.dirtg(e,c)
	return not Duel.IsExistingMatchingCard(aux.FilterEqualFunction(Card.GetFlagEffect,0,id),c:GetControler(),0,LOCATION_MZONE,1,nil)
end
function s.filter(c)
	return (c:IsNormalSpell() or c:IsQuickPlaySpell()) and c:GetActivateEffect()
		and c:GetFlagEffect(id+1)==0
end
function s.activ(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(id+1)==0 then
			local te=tc:GetActivateEffect()
			local e1=Effect.CreateEffect(tc)
			e1:SetCategory(te:GetCategory())
			e1:SetType(EFFECT_TYPE_ACTIVATE)
			if tc:GetType()==TYPE_SPELL then
				e1:SetCode(EVENT_FREE_CHAIN)
			else
				e1:SetCode(te:GetCode())
			end
			e1:SetProperty(te:GetProperty())
			e1:SetCondition(s.con)
			e1:SetCost(s.cos)
			e1:SetTarget(s.tar)
			e1:SetOperation(te:GetOperation())
			e1:SetRange(LOCATION_HAND)
			e1:SetValue(LOCATION_MZONE)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(id+1,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
		end
		tc=g:GetNext()
	end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetHandler():GetActivateEffect()
	local condition=te:GetCondition()
	return (not condition or condition(e,tp,eg,ep,ev,re,r,rp)) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
end
function s.cos(e,tp,eg,ep,ev,re,r,rp,chk)
	local te=e:GetHandler():GetActivateEffect()
	local co=te:GetCost()
	if chk==0 then return not co or co(e,tp,eg,ep,ev,re,r,rp,0) end
	if co then co(e,tp,eg,ep,ev,re,r,rp,1) end
end
function s.tar(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local te=c:GetActivateEffect()
	local tg=te:GetTarget()
	local op=te:GetOperation()
	if chk==0 then return (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)) and Duel.IsTurnPlayer(tp)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,31829185)
	end
	c:CreateEffectRelation(e)
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1,nil) end
	e:SetOperation(op)
end