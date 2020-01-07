--ダークマミー・サージカル・クーパー
--Dark Mummy Surgical Forceps
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x56f),3,3)
	c:EnableReviveLimit()
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(114932,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(122520,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_MSET)
	c:RegisterEffect(e5)
end
function s.atkval(e,c)
	return c:GetLinkedGroupCount()*600
end
function s.filter(c)
	return c:IsType(TYPE_TRAP) and not c:IsPublic()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep==tp and eg:IsExists(s.filter,1,nil) end
	local g=eg:Filter(s.filter,nil)
	if #g==1 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg=g:Select(tp,1,1,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
	end
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.cfilter(c,tp,zone,e)
	local seq=c:GetSequence()
	if c:IsControler(tp) then seq=seq+16 end
	return bit.extract(zone,seq)~=0 and (not e or c:IsRelateToEffect(e))
end
function s.lkfilter(c)
	return c:IsFaceup() and c:IsLinkMonster()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=0
	local lg=Duel.GetMatchingGroup(s.lkfilter,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(lg) do
		zone=zone|tc:GetLinkedZone()
	end
	if chk==0 then return eg:IsExists(s.cfilter,1,nil,tp,zone) end
	Duel.SetTargetCard(eg)
	local g=eg:Filter(s.cfilter,nil,tp,zone)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=0
	local lg=Duel.GetMatchingGroup(s.lkfilter,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(lg) do
		zone=zone|tc:GetLinkedZone()
	end
	local g=eg:Filter(s.cfilter,nil,tp,zone,e)
	Duel.Destroy(g,REASON_EFFECT)
end