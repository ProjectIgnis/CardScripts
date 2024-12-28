--サラマンドラ・フュージョン
--Salamandra Fusion
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a FIRE Warrior monster
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	--Equipped monster gains 700 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(700)
	c:RegisterEffect(e1)
	--Destruction replacement for the equipped monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(s.replacetg)
	e2:SetOperation(s.replaceop)
	c:RegisterEffect(e2)
	--Special Summon 1 "Flame Swordsman" or 1 Fusion Monster that mentions it from your Extra Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcond)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_FLAME_SWORDSMAN}
function s.eqfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR)
end
function s.replacetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec:IsReason(REASON_EFFECT|REASON_BATTLE) and not ec:IsReason(REASON_REPLACE)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.replaceop(e,tp,eg,ep,ev,re,r,rp,chk)
	e:GetHandler():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT|REASON_REPLACE)
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsType(TYPE_FUSION) and ec:IsControler(tp)
end
function s.spfilter(c,e,tp,mc)
	return (c:IsCode(CARD_FLAME_SWORDSMAN) or (c:IsType(TYPE_FUSION) and c:ListsCode(CARD_FLAME_SWORDSMAN)))
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return c:IsAbleToGrave() and ec:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,ec) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,Group.FromCards(c,ec),2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not (c:IsRelateToEffect(e) and ec) then return end
	local g=Group.FromCards(c,ec)
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 or g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	if not sc then return end
	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
	end
end