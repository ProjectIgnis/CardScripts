--Performapal Sandwich Wingman
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95100067,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
	--lvup
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26082117,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	--lv change
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95100067,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.lvtg2)
	e3:SetOperation(s.lvop2)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetOperation(s.checkop)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.cfilter(c)
	local seq=c:GetSequence()
	return c:GetFlagEffect(id+seq)==0 and (not c:IsPreviousLocation(LOCATION_PZONE) or c:GetPreviousSequence()~=seq)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tot=Duel.IsDuelType(DUEL_SEPARATE_PZONE) and 13 or 4
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_PZONE,LOCATION_PZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:ResetFlagEffect(id+tot-tc:GetSequence())
		Duel.RaiseSingleEvent(tc,EVENT_CUSTOM+id,e,0,tp,tp,0)
		tc:RegisterFlagEffect(id+tc:GetSequence(),RESET_EVENT+RESETS_STANDARD,0,1)
		tc=g:GetNext()
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	local ls,rs=tc:GetLeftScale(),tc:GetRightScale()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(ls)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(rs)
		c:RegisterEffect(e2)
	end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.seqfilter(c,e,tp,seq1,lv,e2)
	local lvtg=c:GetLevel()
	local seq=c:GetSequence()
	return (seq==1 or seq==2 or seq==3) and lvtg~=lv and (not e or c:IsRelateToEffect(e)) 
		and (not e2 or c:IsCanBeEffectTarget(e2))
		and Duel.IsExistingMatchingCard(s.seqfilter2,tp,LOCATION_MZONE,0,1,nil,seq1,lv,seq)
end
function s.seqfilter2(c,seq1,lv1,seq)
	local seq2=c:GetSequence()
	return c:IsFaceup() and c:GetLevel()==lv1 and ((seq1>seq and seq>seq2) or (seq2>seq and seq>seq1))
end
function s.lvtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local seq=e:GetHandler():GetSequence()
	local lv=e:GetHandler():GetLevel()
	local ct1=Duel.GetMatchingGroupCount(s.seqfilter,tp,LOCATION_MZONE,0,nil,nil,tp,seq,lv,nil)
	local ct2=Duel.GetMatchingGroupCount(s.seqfilter,tp,LOCATION_MZONE,0,nil,nil,tp,seq,lv,e)
	if chkc then return false end
	if chk==0 then return ct1>0 and ct2>0 and ct1==ct2 end
	local g=Duel.GetMatchingGroup(s.seqfilter,tp,LOCATION_MZONE,0,nil,nil,tp,seq,lv,e)
	Duel.SetTargetCard(g)
end
function s.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local seq=c:GetSequence()
	local lv=c:GetLevel()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.seqfilter,nil,e,tp,seq,lv,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

