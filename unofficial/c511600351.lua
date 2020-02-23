--グッサリ＠イグニスター (Anime)
--Gussari @Ignister (Anime)
--Scripted by Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCode()
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(alias,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,alias)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(alias,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,alias+100)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(alias,2))
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,alias+200)
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(s.btcon)
	e3:SetTarget(s.bttg)
	e3:SetOperation(s.btop)
	c:RegisterEffect(e3)
end
s.listed_series={0x135}
function s.cfilter(c)
	return c:GetPreviousTypeOnField()&TYPE_LINK==TYPE_LINK
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsType(TYPE_LINK) and tc:GetLinkedGroup():IsContains(e:GetHandler())
		and tc:IsRelateToBattle() and tc:IsStatus(STATUS_OPPO_BATTLE)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam=eg:GetFirst():GetAttack()
	if chk==0 then return dam>0 end
	Duel.SetTargetCard(eg:GetFirst())
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=eg:GetFirst():GetAttack()
		if dam<0 then dam=0 end
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
function s.btcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if not at then return false end
	if not a:IsControler(tp) then a,at=at,a end
	return a:IsType(TYPE_LINK) and a:IsSetCard(0x135) and a:IsControler(tp) and not at:IsControler(tp)
end
function s.bttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if chk==0 then
		if not at then return false end
		if not a:IsControler(tp) then a,at=at,a end
		return a:IsType(TYPE_LINK) and a:IsSetCard(0x135) and a:IsControler(tp) and not at:IsControler(tp)
	end
	local tc=a:IsControler(tp) and a or at
	Duel.SetTargetCard(tc)
end
function s.btop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a:IsFaceup() and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(3000)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		a:RegisterEffect(e1)
		local e2=e1:Clone()
		d:RegisterEffect(e2)
	end
	local tc=a:IsControler(tp) and a or d
	if tc:IsRelateToEffect(e) then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e3:SetLabel(tc:GetLink())
		e3:SetOperation(s.spop)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.spfilter(c,e,tp,lk)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x135) and c:GetLink()<lk
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,0,1,nil,e,tp,e:GetLabel())
	if #g>0 then
	   Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) 
	end
end
