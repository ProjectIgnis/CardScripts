--原石竜ネザー・ベルセリウス
--Primite Dragon Nether Berzelius
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "Primite" monster + 1+ Normal Monsters
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_NORMAL),1,99,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PRIMITE))
	--Gains 1000 ATK for each Normal Monster used for its Fusion Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(function(e,c) c:UpdateAttack(c:GetMaterial():FilterCount(Card.IsType,nil,TYPE_NORMAL)*1000,RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD) end)
	c:RegisterEffect(e1)
	--Negate the activated effects of monsters your opponent controls whose Level/Rank/Link Rating is less than or equal to the number of Normal Monsters in your field and GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.Hint(HINT_CARD,0,id) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e2)
	--Special Summon 1 Normal Monster from your Deck in Defense Position
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_PRIMITE}
s.material_setcode={SET_PRIMITE}
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsMonsterEffect() or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local normal_ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_NORMAL),tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if normal_ct==0 then return false end
	local trig_ctrl,trig_loc,trig_lv,trig_rk=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_LEVEL,CHAININFO_TRIGGERING_RANK)
	if not (trig_ctrl==1-tp and trig_loc==LOCATION_MZONE) then return false end
	local trig_lk=re:GetHandler():GetLink()
	if trig_lv>0 and trig_lv<=normal_ct then return true end
	if trig_rk>0 and trig_rk<=normal_ct then return true end
	if trig_lk>0 and trig_lk<=normal_ct then return true end
	return false
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end