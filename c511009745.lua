--キャプチャー・ドローン
--Capture Drone
--Credits to Cybercatman
--fixed by Logical Nonsense & Larry126 and MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPersistentProcedure(c,1,s.filter,CATEGORY_DISABLE,nil,nil,nil,s.condition,nil,s.target)
	--effs
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--Self-destruction
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(s.descon)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
	--Tokens
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(s.tkcon)
	e6:SetTarget(s.tktg)
	e6:SetOperation(s.tkop)
	c:RegisterEffect(e6)
	--cannot attack
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_ATTACK)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(0,LOCATION_MZONE)
	e7:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_LINK))
	c:RegisterEffect(e7)
end
s.listed_series={0x581}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x581)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c)
	return c:IsFaceup() and c:IsLinkMonster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x581,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_WIND)
		and e:GetHandler():GetFirstCardTarget():GetLink()>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ft=math.min(c:GetFirstCardTarget():GetLink(),Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x581,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_WIND) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=ft
	if ft~=1 then
		local selct = {}
		for i=1,ft do
			selct[i]=i
		end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(15341821,0))
		ct=Duel.AnnounceNumber(tp,table.unpack(selct))
	end
	for i=1,ct do
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end
