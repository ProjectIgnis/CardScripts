--フィーライン・サーバント
--Feline Friend
--Scripted by Eerie Code
function c120401053.initial_effect(c)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c120401053.dacon)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(120401053,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,120401053)
	e2:SetCondition(c120401053.spcon)
	e2:SetTarget(c120401053.sptg)
	e2:SetOperation(c120401053.spop)
	c:RegisterEffect(e2)
end
function c120401053.dafilter(c)
	return c:IsDefensePos() or c:IsType(TYPE_LINK)
end
function c120401053.dacon(e)
	return not Duel.IsExistingMatchingCard(aux.NOT(c120401053.dafilter),e:GetHandler():GetControler(),0,LOCATION_MZONE,1,nil)
end
function c120401053.spcfilter(c,e,tp)
	if c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsRace(RACE_WARRIOR) and c:IsControler(tp) then
		local zone=c:GetLinkedZone()
		return zone~=0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
	else return false end
end
function c120401053.spcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c120401053.spcfilter,1,nil,e,tp) and Duel.IsChainNegatable(ev)
end
function c120401053.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c120401053.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):Filter(c120401053.spcfilter,nil,e,tp)
	local zone=0
	for tc in aux.Next(tg) do
		zone=bit.bor(zone,tc:GetLinkedZone())
	end
	if zone~=0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)~=0 
		and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)		
	end
end
