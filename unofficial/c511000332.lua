--フュージョン・バスター
--Fusion Buster
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--De-fusion
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
	--Negate Polymerization
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.polycon)
	e3:SetCost(s.polycost)
	e3:SetTarget(s.polytg)
	e3:SetOperation(s.polyop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_POLYMERIZATION}
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.mgfilter(c,e,tp,fusc)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE)
		and c:GetReason()&0x40008==0x40008 and c:GetReasonCard()==fusc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local mg=tc:GetMaterial()
	local ct=#mg
	if Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0 and tc:GetSummonType()&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
		and ct>0 and ct<=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		and mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,tc,mg)==ct
		and (not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or ct==1) then
		Duel.BreakEffect()
		Duel.SpecialSummon(mg,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
function s.polycon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(CARD_POLYMERIZATION) and Duel.IsChainNegatable(ev)
end
function s.polycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.polytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.polyop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end