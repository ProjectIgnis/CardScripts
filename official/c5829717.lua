--竜魔導騎士ブラック・マジシャン
--Dark Magician the Knight of Dragon Magic
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Material
	Fusion.AddProcMix(c,true,true,CARD_DARK_MAGICIAN,s.ffilter)
	--Your monsters deal piercing damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	c:RegisterEffect(e1)
	--Inflict damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--Special Summon 1 "Dark Magician" and 1 "Gaia the Dragon Champion"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_DARK_MAGICIAN,CARD_GAIA_CHAMPION}
local LOCATION_HAND_DECK_GRAVE_EXTRA=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_EXTRA
function s.ffilter(c,fc,sumtype,tp)
	return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON|RACE_WARRIOR,fc,sumtype,tp)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:Filter(Card.IsPreviousControler,nil,1-tp)
	if #dg==0 or #dg>1 then return false end
	local rc=dg:GetFirst():GetReasonCard()
	if rc:IsRelateToBattle() then
		return rc:IsControler(tp)
	else
		return rc:IsPreviousControler(tp)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=eg:Filter(Card.IsPreviousControler,nil,1-tp):GetFirst()
	if chk==0 then return dc and dc:GetBaseAttack()>0 end
	local dam=dc:GetBaseAttack()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_DARK_MAGICIAN,CARD_GAIA_CHAMPION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,CARD_DARK_MAGICIAN)==1
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND_DECK_GRAVE_EXTRA,0,nil,e,tp)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND_DECK_GRAVE_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND_DECK_GRAVE_EXTRA,0,nil,e,tp)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end