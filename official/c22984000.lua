--JP name
--Mercurium the Living Quicksilver
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 10 monsters
	Xyz.AddProcedure(c,nil,10,2,nil,nil,Xyz.InfiniteMats)
	--If this card is Xyz Summoned: You can attach 1 monster from your Deck to this card as material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e1:SetTarget(s.attachtg)
	e1:SetOperation(s.attachop)
	c:RegisterEffect(e1)
	--While this card has material, your opponent cannot activate the effects of monsters in their GY with the same Attribute as a monster in your GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>0 end)
	e2:SetValue(s.cannotactval)
	c:RegisterEffect(e2)
	--Once per turn, during the End Phase: Detach 1 material from this card or take 3000 damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.detachtg)
	e3:SetOperation(s.detachop)
	c:RegisterEffect(e3)
end
function s.attachfilter(c,xyzc,tp)
	return c:IsMonster() and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler(),tp) end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_DECK,0,1,1,nil,c,tp):GetFirst()
		if sc then
			Duel.Overlay(c,sc)
		end
	end
end
function s.cannotactval(e,re,rp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsLocation(LOCATION_GRAVE)
		and Duel.IsExistingMatchingCard(Card.IsAttribute,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,rc:GetAttribute())
end
function s.detachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	if c:GetOverlayCount()==0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,3000)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,3000)
end
function s.detachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return Duel.Damage(tp,3000,REASON_EFFECT) end
	local b1=c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
	local b2=true
	--Detach 1 material from this card or take 3000 damage
	local op=b1 and Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)}) or 2
	if op==1 then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	elseif op==2 then
		Duel.Damage(tp,3000,REASON_EFFECT)
	end
end