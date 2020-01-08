--インターフェアレンス・キャンセラー
--Interference Canceller
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPersistentProcedure(c,0,s.filter,nil,nil,nil,0x1e0,nil,nil,nil,s.activate)
	--Make damage 0
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_F)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.damcon) 
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.labelcon)
	e2:SetOperation(s.labelop)
	c:RegisterEffect(e2)
	--reset during End Phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35498188,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsType(TYPE_LINK) and c:GetMutualLinkedGroupCount()>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return aux.damcon1(e,tp,eg,ep,ev,re,r,rp,chk) and rp~=tp
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local label=c:GetFlagEffectLabel(id+100)
	if chk==0 then return c:GetFirstCardTarget()~=nil
		and label and label>0 end
	c:SetFlagEffectLabel(id+100,label-1)
end 
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(cid)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.damval(e,re,val,r,rp,rc)
	local cc=Duel.GetCurrentChain()
	if cc==0 or r&REASON_EFFECT==0 then return end
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0 end
	return val
end
function s.labelcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFirstCardTarget()~=nil and e:GetHandler():GetFlagEffect(id+100)==0
end
function s.labelop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,e:GetHandler():GetFirstCardTarget():GetLink())
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFirstCardTarget()~=nil and e:GetHandler():GetFlagEffect(id)>0
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end
