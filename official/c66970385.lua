--聖騎士伝説の終幕
--Last Chapter of the Noble Knights
local s,id=GetID()
function s.initial_effect(c)
	--If your opponent controls a monster and you control no monsters: You can target 1 "Noble Arms" Equip Spell Card and 1 appropriate "Noble Knight" monster in your Graveyard; Special Summon that monster, and if you do, equip that Equip Spell Card to that appropriate monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NOBLE_ARMS,SET_NOBLE_KNIGHT}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.tgfilter(c,e,tp)
	return (c:IsSetCard(SET_NOBLE_ARMS) and c:IsEquipSpell() and c:CheckUniqueOnField(tp))
		or (c:IsSetCard(SET_NOBLE_KNIGHT) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.rescon(sg,e,tp,mg)
	local monster=sg:Filter(Card.IsMonster,nil):GetFirst()
	local spell=sg:Filter(Card.IsEquipSpell,nil):GetFirst()
	return monster and spell and spell:CheckEquipTarget(monster)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetTargetGroup(s.tgfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
		return ft>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>=2
			and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
		end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	local monster,spell=tg:Split(Card.IsMonster,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,monster,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,spell,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local monster=tg:Filter(Card.IsMonster,nil):GetFirst()
	local spell=tg:Filter(Card.IsEquipSpell,nil):GetFirst()
	if monster and Duel.SpecialSummon(monster,0,tp,tp,false,false,POS_FACEUP)>0 and spell
		and spell:CheckUniqueOnField(tp) and spell:CheckEquipTarget(monster) then
		Duel.Equip(tp,spell,monster)
	end
end