--F.A. Dead Heat
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK)
	e1:SetTarget(s.acttg)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--atk up
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_LVCHANGE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(s.lvlcost)
	e3:SetCondition(s.lvlcon)
	e3:SetOperation(s.lvlop)
	c:RegisterEffect(e3)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	if Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) then
		if s.spcon(e,tp,eg,ep,ev,re,r,rp)
			and s.spcost(e,tp,eg,ep,ev,re,r,rp,0)
			and s.sptg(e,tp,eg,ep,ev,re,r,rp,0)
			and Duel.SelectYesNo(tp,94) then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(0)
			e:SetOperation(s.spop)
			s.spcost(e,tp,eg,ep,ev,re,r,rp,1)
			s.sptg(e,tp,eg,ep,ev,re,r,rp,1)
			e:GetHandler():RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,65)
			return
		end
	end
	if Duel.CheckEvent(EVENT_BATTLE_CONFIRM) then
		if s.lvlcon(e,tp,eg,ep,ev,re,r,rp)
			and s.lvlcost(e,tp,eg,ep,ev,re,r,rp,0)
			and Duel.SelectYesNo(tp,94) then
			e:SetCategory(CATEGORY_LVCHANGE+CATEGORY_DESTROY)
			e:SetProperty(0)
			e:SetOperation(s.lvlop)
			s.lvlcost(e,tp,eg,ep,ev,re,r,rp,1)
			e:GetHandler():RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,65)
			return
		end
	end
	e:SetCategory(0)
	e:SetProperty(0)
	e:SetOperation(nil)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end



function s.lvlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.lvlcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then bc,tc=tc,bc end
	return bc:IsFaceup() and tc:IsFaceup() and tc:IsSetCard(0x107)
end
function s.lvlop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then bc,tc=tc,bc end
	local d1=0
	local d2=0
	while d1==d2 do
		d1,d2=Duel.TossDice(tp,1,1)
	end
	if d1>d2 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(4)
		tc:RegisterEffect(e1)
	else
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

