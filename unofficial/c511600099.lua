--クラスター・コンジェスター (Anime)
--Cluster Congester (Anime)
--Scripted by Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	local g=Group.CreateGroup()
	g:KeepAlive()
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e0:SetCode(EVENT_PHASE+PHASE_END)
	e0:SetLabelObject(g)
	e0:SetRange(0x7e)
	e0:SetCondition(s.descon)
	e0:SetTarget(s.destg)
	e0:SetOperation(s.desop)
	c:RegisterEffect(e0)
	--token
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetLabelObject(e0)
	e1:SetCountLimit(1,alias)
	e1:SetCondition(s.tkcon1)
	e1:SetTarget(s.tktg1)
	e1:SetOperation(s.tkop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--tokens
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_BATTLE_PHASE)
	e3:SetLabelObject(e0)
	e3:SetCondition(s.tkcon2)
	e3:SetCost(s.tkcost2)
	e3:SetTarget(s.tktg2)
	e3:SetOperation(s.tkop2)
	c:RegisterEffect(e3)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=e:GetLabelObject():Filter(Card.IsOnField,nil)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,LOCATION_ONFIELD)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*300)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(Card.IsOnField,nil)
	if #g>0 then
		local ct=Duel.Destroy(g,REASON_EFFECT)
		Duel.Damage(1-tp,ct*300,REASON_EFFECT)
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsLinkMonster()
end
function s.tkcon1(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,alias+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,alias+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then
		local tk=Duel.CreateToken(tp,alias+1)
		Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP)
		e:GetLabelObject():GetLabelObject():AddCard(tk)
	end
end
function s.tkcon2(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	return at and at:IsFaceup() and at:IsLinkMonster()
end
function s.tkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.GetAttackTarget():IsAbleToRemoveAsCost() end
	local g=Group.FromCards(e:GetHandler(),Duel.GetAttackTarget())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,Duel.GetAttackTarget())>0 
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,Duel.GetAttackTarget())
		and Duel.IsPlayerCanSpecialSummonMonster(tp,alias+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,alias+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then return end
	local ct=math.min(Duel.GetMatchingGroupCount(s.filter,tp,0,LOCATION_MZONE,nil),Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ct<1 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	repeat
		local token=Duel.CreateToken(tp,alias+1)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		e:GetLabelObject():GetLabelObject():AddCard(token)
		ct=ct-1
	until ct<=0 or not Duel.SelectYesNo(tp,aux.Stringid(alias,0))
	Duel.SpecialSummonComplete()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
