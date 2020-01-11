--EMオッドアイズ・シンクロン
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--eff
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.indcon)
	e1:SetOperation(s.indop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8873112,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(LOCATION_PZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.indcon2)
	e2:SetTarget(s.indtg)
	e2:SetOperation(s.indop2)
	c:RegisterEffect(e2)
	--synchro
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82224646,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.sctg)
	e4:SetOperation(s.scop)
	c:RegisterEffect(e4)
end
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	return tc and tc:IsType(TYPE_TUNER) and tc:IsControler(tp) and tc:IsRelateToBattle()
end
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	if not tc or tc:IsControler(1-tp) or not tc:IsRelateToBattle() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	tc:RegisterEffect(e1)
end
function s.cfilter(c,e,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsType(TYPE_TUNER) and (not e or c:IsRelateToEffect(e))
end
function s.indcon2(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil,nil,tp)-#tg>0
end
function s.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	Duel.SetTargetCard(tg)
end
function s.indop2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(s.cfilter,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_CHAIN)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
function s.scfilter1(c,tp,mc)
	return Duel.IsExistingMatchingCard(s.scfilter2,tp,LOCATION_PZONE,0,1,nil,mc,c)
end
function s.scfilter2(c,mc,sc)
	local mg=Group.FromCards(c,mc)
	return c:IsCanBeSynchroMaterial(sc) and sc:IsSynchroSummonable(nil,mg)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,c)>0
		and Duel.IsExistingMatchingCard(s.scfilter1,tp,LOCATION_EXTRA,0,1,nil,tp,c) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCountFromEx(tp,tp,c)<=0 then return end
	local g=Duel.GetMatchingGroup(s.scfilter1,tp,LOCATION_EXTRA,0,nil,tp,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local mg=Duel.SelectMatchingCard(tp,s.scfilter2,tp,LOCATION_PZONE,0,1,1,nil,c,sc)
		mg:AddCard(c)
		Duel.SynchroSummon(tp,sc,nil,mg)
	end
end
