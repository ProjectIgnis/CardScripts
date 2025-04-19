--ワクチンの接種
--Vaccination
--scripted by Naim
local s,id=GetID()
local COUNTER_VACCINE=0x1108
function s.initial_effect(c)
	--Equip and place 1 Vaccine counter on the equipped monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.equiptg)
	e1:SetOperation(s.equipop)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Monsters with Vaccine Counters are unaffected by the effect if "Virus" cards
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(function(e,cc) return cc:GetCounter(COUNTER_VACCINE)>0 end)
	e3:SetValue(function(e,te) return te:GetHandler():IsVirus() end)
	c:RegisterEffect(e3)
	--Equip it to a monster that was Fusion/Tribute summoned using the previous equip target
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e4:SetCondition(s.reeqcond)
	e4:SetTarget(s.reeqtg)
	e4:SetOperation(s.reeqop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
s.counter_place_list={COUNTER_VACCINE}
s.viruses={86361354,33184167,24725825,22804644,48736598,84121193,4931121,35027493,39163598,
54591086,54974237,57728570,84491298,85555787,100000166,511002576,511005713,511009657,511001119}
function Card.IsVirus(c)
	local code=c:GetCode()
	for _,virus_card in ipairs(s.viruses) do
		if code==virus_card then return true end
	end
	return false
end
function s.equiptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g:GetFirst(),1,0,COUNTER_VACCINE)
end
function s.equipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	if Duel.Equip(tp,c,tc) then
		Duel.BreakEffect()
		tc:AddCounter(COUNTER_VACCINE,1)
	end
end
function s.reeqcond(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return (tc:IsTributeSummoned() or tc:IsFusionSummoned())
		and tc:GetMaterial():IsContains(e:GetHandler():GetPreviousEquipTarget())
end
function s.cfilter(c,e,oldec)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:GetMaterial():IsContains(oldec)
end
function s.reeqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	if chkc then return eg:IsContains(chkc) and s.cfilter(chkc,e,ec) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and eg:IsExists(s.cfilter,1,nil,e,ec) end
	local tc=nil
	if #eg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		tc=eg:FilterSelect(tp,s.cfilter,1,1,nil,e,ec)
	else
		tc=eg:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,tc,1,0,COUNTER_VACCINE)
end
function s.reeqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	s.equipop(e,tp,eg,ep,ev,re,r,rp)
end