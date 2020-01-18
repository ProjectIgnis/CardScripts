--涅槃の超魔導剣士 (Anime)
--Nirvana High Paladin (Anime)
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c,false)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80896940,1))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	e1:SetCondition(s.sprcon)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	--peffect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89127526,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_PZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg2)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--pendulum
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80896940,5))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
function s.cfilter(c,e)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:GetTurnID()==Duel.GetTurnCount()
		and (not e or c:IsCanBeEffectTarget(e))
end
function s.cfilter2(c,tc)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:GetTurnID()==Duel.GetTurnCount()
		and tc and c:IsLevel(tc:GetLevel()+1)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter2(chkc,tc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,tc) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=Duel.SelectTarget(tp,s.cfilter2,tp,LOCATION_MZONE,0,1,1,nil,tc)
	c:CancelCardTarget(tc)
	c:SetCardTarget(tg:GetFirst())
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,e)
	local rg,lv=g:GetMinGroup(Card.GetLevel)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=g:FilterSelect(tp,Card.IsLevel,1,1,nil,lv)
	Duel.SetTargetCard(tg)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if tc then
		c:CancelCardTarget(tc)
	end
	c:SetCardTarget(tg:GetFirst())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(s.atkop2)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e3)
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-c:GetAttack())
		tc:RegisterEffect(e1)
	end
end
function s.sfilter(c,tp,sc)
	local rg=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_MZONE,0,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsReleasable() and c:IsLevelBelow(2147483647)
		and rg:IsExists(s.filterchk,1,nil,rg,Group.CreateGroup(),tp,c,sc)
end
function s.pfilter(c)
	return c:IsLevelBelow(2147483647) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsReleasable()
end
function s.filterchk(c,g,sg,tp,sync,sc)
	sg:AddCard(c)
	sg:AddCard(sync)
	local res=Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0 
		and sg:CheckWithSumEqual(Card.GetLevel,10,#sg,#sg)
	sg:RemoveCard(sync)
	if not res then
		res=g:IsExists(s.filterchk,1,sg,g,sg,tp,sync,sc)
	end
	sg:RemoveCard(c)
	return res
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_MZONE,0,1,nil,tp,c)
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	local sync=g:GetFirst()
	local rg=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_MZONE,0,sync)
	local tc
	local mg=Group.CreateGroup()
	while true do
		local tg=rg:Filter(s.filterchk,mg,rg,mg,tp,sync,c)
		if #tg<=0 then break end
		mg:AddCard(sync)
		local cancel=#mg>1 and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0 
			and mg:CheckWithSumEqual(Card.GetLevel,10,#mg,#mg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		tc=Group.SelectUnselect(tg,mg,tp,cancel,cancel)
		if not tc then break end
		mg:RemoveCard(sync)
		if tc~=sync then
			if mg:IsContains(tc) then
				mg:RemoveCard(tc)
			else
				mg:AddCard(tc)
			end
		end
	end
	mg:Merge(g)
	Duel.Release(mg,REASON_COST)
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
