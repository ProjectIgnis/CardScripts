--ダーク・ネクロフィア (Manga)
--Dark Necrofear (Manga)
--Scripted by Edo9300
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--possess
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.con1)
	e2:SetOperation(s.op1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.con2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)
	--Gain and Damage
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(s.dmcon)
	e4:SetTarget(s.dmtg)
	e4:SetOperation(s.dmop)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsMonster() and tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsPreviousPosition(POS_ATTACK) then
			tc:RegisterFlagEffect(id+1,RESET_PHASE|PHASE_END,0,5)
		end
	end
end
function s.spcfilter(c,ft)
	return c:GetFlagEffect(id+1)>0 and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if chk==0 then return #rg>2 and aux.SelectUnselectGroup(rg,e,tp,3,3,aux.ChkfMMZ(1),0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and e:GetHandler():GetFlagEffect(id+2)==0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		e:GetHandler():RegisterFlagEffect(id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():GetFlagEffect(id)>0 and not Duel.GetAttacker():IsControler(tp)
end
function s.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=Duel.GetAttacker()
	local dam=c:GetAttack()/2
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttacker()
	local dam=c:GetAttack()/2
	if Duel.NegateAttack() then
		Duel.Recover(tp,dam,REASON_EFFECT)
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end