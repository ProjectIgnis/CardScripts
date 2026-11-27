--闇魔導の覇王
--King of Yamimado
--scripted by Naim
local s,id=GetID()
local CARD_YAMI=59197169
function s.initial_effect(c)
	--While you control a face-down card, this card cannot be destroyed by your opponent's card effects
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetValue(aux.indoval)
	e1a:SetCondition(function(e)
		return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
	end)
	c:RegisterEffect(e1a)
	--Also, your opponent cannot target it with card effects
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1b:SetValue(aux.tgoval)
	c:RegisterEffect(e1b)
	--If this card is in your hand and 2 or more face-down cards and/or "Yami" are on the field: You can Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--When a monster on the field with less ATK than this card activates its effect or declares an attack (Quick Effect): You can destroy that monster
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_DESTROY)
	e3a:SetType(EFFECT_TYPE_QUICK_O)
	e3a:SetCode(EVENT_CHAINING)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetCountLimit(1,{id,1})
	e3a:SetCondition(s.descon)
	e3a:SetTarget(s.destg)
	e3a:SetOperation(s.desop)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3b:SetCondition(s.descon2)
	e3b:SetOperation(s.desop2)
	c:RegisterEffect(e3b)
end
s.listed_names={CARD_YAMI}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,nil)
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_YAMI),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and Chain.IsTriggeringLocation(ev,LOCATION_MZONE) and rc:IsRelateToEffect(re)
		and rc:GetAttack()<e:GetHandler():GetAttack() and rc:IsFaceup()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	local rc=Duel.GetAttacker()
	return rc:IsOnField() and rc:GetAttack()<e:GetHandler():GetAttack()
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local rc=Duel.GetAttacker()
	if rc:IsRelateToBattle() then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end