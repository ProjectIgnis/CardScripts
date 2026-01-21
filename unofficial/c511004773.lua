--Last Counter (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NUMBER}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and eg:GetFirst():IsPreviousControler(tp)
end
function s.numberfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_NUMBER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst():GetReasonCard()
	if chkc then return chkc==tc end
	if chk==0 then
		return tc:IsRelateToBattle() and tc:IsCanBeEffectTarget(e)
			and tc:GetAttack()>0 and Duel.IsExistingMatchingCard(s.numberfilter,tp,LOCATION_MZONE,0,1,tc) 
	end
	Duel.SetTargetCard(tc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local sc=Duel.SelectMatchingCard(tp,s.numberfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if sc then
		    Duel.HintSelection(sc)
			local e2=Effect.CreateEffect(c)
		    e2:SetType(EFFECT_TYPE_SINGLE)
		    e2:SetCode(EFFECT_UPDATE_ATTACK)
		    e2:SetValue(atk)
		    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		    sc:RegisterEffect(e2)
		end	
	    --des register
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DESTROY)
		e3:SetOperation(s.desop)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE+PHASE_BATTLE)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if eg:IsContains(tc) and tc:GetFlagEffect(id)>0 and Duel.IsBattlePhase() then
	    --damage
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetCountLimit(1)
		e1:SetTarget(s.damtg)
		e1:SetOperation(s.damop)
		e1:SetLabel(tc:GetBaseAttack())
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,e:GetLabel())
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
