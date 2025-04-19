--暗黒界の魔神 レイン
--Reign-Beaux, Overlord of Dark World
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card if it is discarded to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Destroy all monsters OR all Spells/Traps your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and rp==1-tp
		and (r&(REASON_DISCARD|REASON_EFFECT))==(REASON_DISCARD|REASON_EFFECT)
		and e:GetHandler():IsPreviousControler(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c1=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	local c2=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	if (#c1+#c2)>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,c1+c2,1,tp,0)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	local g2=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	local b1=#g1>0
	local b2=#g2>0
	if not (b1 or b2) then return end
	local op=nil
	if (b1 and b2) then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
	else
		op=(b1 and 1 or 2)
	end
	Duel.Destroy(op==1 and g1 or g2,REASON_EFFECT)
end