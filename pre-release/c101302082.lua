--JP name
--Cursed Copycat Noble Arms
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Equipped monster gains 200 ATK/DEF for each Equip Spell in your field and GY
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_EQUIP)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetValue(s.atkdefval)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	--Special Summon 1 Warrior monster with the same Attribute and Level as the equipped monster but a different name from your Deck, and if you do, equip it with this card, then destroy the monster this card was equipped to
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) local ec=e:GetHandler():GetEquipTarget() return ec and ec:IsRace(RACE_WARRIOR) end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.atkdefvalfilter(c)
	return c:IsEquipSpell() and (c:IsFaceup() or c:GetEquipTarget())
end
function s.atkdefval(e,c)
	return 200*Duel.GetMatchingGroupCount(s.atkdefvalfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
end
function s.spfilter(c,e,tp,attr,lv,code,hc)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(attr) and c:IsLevel(lv) and not c:IsCode(code)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and hc:CheckEquipTarget(c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ec:GetAttribute(),ec:GetLevel(),ec:GetCode(),c) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--You cannot Special Summon for the rest of this turn, except Warrior monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsRace(RACE_WARRIOR) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ec=c:GetEquipTarget()
	if not ec then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ec:GetAttribute(),ec:GetLevel(),ec:GetCode(),c):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.Equip(tp,c,sc) and ec:IsLocation(LOCATION_MZONE) then
		Duel.BreakEffect()
		Duel.Destroy(ec,REASON_EFFECT)
	end
end