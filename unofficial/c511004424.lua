--覇王乱舞
--Supreme Faceoff
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate (Normal activation)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Activate (Battle Timing)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_PHASE|TIMING_BATTLE_START)
	e2:SetCountLimit(1)
	e2:SetCondition(s.forceoppattcon)
	e2:SetTarget(s.forceoppatttg)
	e2:SetOperation(s.forceoppattop)
	c:RegisterEffect(e2)
	--Prevent a "Supreme King" monster(s) from being destroyed by 1 battle or card effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(s.batdescon)
	e3:SetTarget(s.preventdestg)
	e3:SetOperation(s.preventdesop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.effdescon)
	c:RegisterEffect(e4)
	--You can send this card from your field to the GY during your opponent's BP; all monsters they control must attack, if able
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and Duel.IsBattlePhase() end)
	e5:SetCost(Cost.SelfToGrave)
	e5:SetTarget(s.tgforceattacktg)
	e5:SetOperation(s.tgforceattackop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_SUPREME_KING}
function s.forceoppattcon(e,tp,eg,ev,ep,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsBattlePhase()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SUPREME_KING),tp,LOCATION_MZONE,0,1,nil)
end
function s.forceoppattfilter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_CANNOT_ATTACK) and not c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and (c:IsAttackPos() or c:IsHasEffect(EFFECT_DEFENSE_ATTACK))
end
function s.forceoppatttg(e,tp,eg,ev,ep,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.forceoppattfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.forceoppattfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SelectTarget(tp,s.forceattackfilter,tp,0,LOCATION_MZONE,1,1,nil,0)
end
function s.forceoppattop(e,tp,eg,ev,ep,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetTargetCards(e)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		if tc:GetAttackAnnouncedCount()>0 then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_EXTRA_ATTACK)
			e2:SetValue(1)
			tc:RegisterEffect(e2)
		end
	end
end
function s.batdescon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=tc:GetBattleTarget()
	if tc:IsControler(1-tp) then
		tc,bc=bc,tc
	end
	if not tc or not bc or tc:IsControler(1-tp) or not tc:IsSetCard(SET_SUPREME_KING) then return false end
	if tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
		local tcind={tc:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
		for _,te in ipairs(tcind) do
			local f=te:GetValue()
			if type(f)=='function' then
				if f(te,bc) then return false end
			else return false end
		end
	end
	e:SetLabelObject(tc)
	if bc==Duel.GetAttackTarget() and bc:IsDefensePos() then return false end
	if bc:IsPosition(POS_FACEUP_DEFENSE) and bc==Duel.GetAttacker() then
		if not bc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then return false end
		if bc:IsHasEffect(75372290) then
			if tc:IsAttackPos() then
				return bc:GetAttack()>0 and bc:GetAttack()>=tc:GetAttack()
			else
				return bc:GetAttack()>tc:GetDefense()
			end
		else
			if tc:IsAttackPos() then
				return bc:GetDefense()>0 and bc:GetDefense()>=tc:GetAttack()
			else
				return bc:GetDefense()>tc:GetDefense()
			end
		end
	else
		if tc:IsAttackPos() then
			return bc:GetAttack()>0 and bc:GetAttack()>=tc:GetAttack()
		else
			return bc:GetAttack()>tc:GetDefense()
		end
	end
end
function s.effdesfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsSetCard(SET_SUPREME_KING)
end
function s.effdescon(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if tg==nil then return end
	local g=tg:Filter(s.effdesfilter,nil,tp)
	g:KeepAlive()
	e:SetLabelObject(g)
	return ex and tg~=nil and tc+tg:FilterCount(s.effdesfilter,nil,tp)-#tg>0
end
function s.preventdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then return g end
	Duel.SetTargetCard(g)
end
function s.preventdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	for tc in g:Iter() do
		if tc:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
				if e:GetCode()==EVENT_PRE_DAMAGE_CALCULATE then
					e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
					e1:SetValue(1)
					e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
				else
					e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
					e1:SetValue(function(e,te) return re==te end)
					e1:SetReset(RESET_CHAIN)
				end
			tc:RegisterEffect(e1)
		end
	end
	g:DeleteGroup()
end
function s.tgforceattacktg(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.forceoppattfilter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.tgforceattackop(e,tp,eg,ev,ep,re,r,rp)
	local g=Duel.GetMatchingGroup(s.forceoppattfilter,tp,0,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetReset(RESET_PHASE|PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
	if #g==0 then return end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetReset(RESET_PHASE|PHASE_BATTLE)
	e2:SetTargetRange(0,1)
	Duel.RegisterEffect(e2,tp)
end
