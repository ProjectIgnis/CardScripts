--ＢＦ－朧影のゴウフウ
--Blackwing - Gofu the Vague Shadow
local s,id=GetID()
local TOKEN_VAGUE_SHADOW=id+1
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must first be Special Summoned (from your hand) while you control no monsters
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.selfspcon)
	c:RegisterEffect(e0)
	--Special Summon 2 "Vague Shadow Tokens" (Winged Beast/DARK/Level 1/ATK 0/DEF 0), but they cannot be Tributed or be used as Synchro Material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_HAND) end)
	e1:SetTarget(s.tokentg)
	e1:SetOperation(s.tokenop)
	c:RegisterEffect(e1)
	--Special Summon 1 "Blackwing" Synchro Monster whose Level equals the total Levels the banished monsters had on the field from your GY as a Tuner
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.gyspcost)
	e2:SetTarget(s.gysptg)
	e2:SetOperation(s.gyspop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_VAGUE_SHADOW}
s.listed_series={SET_BLACKWING}
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_VAGUE_SHADOW,0,TYPES_TOKEN,0,0,1,RACE_WINGEDBEAST,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_VAGUE_SHADOW,0,TYPES_TOKEN,0,0,1,RACE_WINGEDBEAST,ATTRIBUTE_DARK) then
		local c=e:GetHandler()
		for i=1,2 do
			local token=Duel.CreateToken(tp,TOKEN_VAGUE_SHADOW)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			--They cannot be Tributed or be used as Synchro Material
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3303)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			token:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetDescription(3310)
			e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			token:RegisterEffect(e3)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.gyspcostfilter(c)
	return not c:IsType(TYPE_TUNER) and c:HasLevel() and c:IsFaceup() and c:IsAbleToRemoveAsCost()
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0 and Duel.IsExistingTarget(s.gyspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,sg:GetSum(Card.GetLevel)+e:GetHandler():GetLevel())
end
function s.gyspfilter(c,e,tp,lv)
	if not (c:IsSetCard(SET_BLACKWING) and c:IsSynchroMonster() and c:IsLevel(lv)) then return false end
	c:AssumeProperty(ASSUME_TYPE,c:GetType()|TYPE_TUNER)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gyspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.gyspcostfilter,tp,LOCATION_MZONE,0,c)
	if chk==0 then return c:IsAbleToRemoveAsCost() and c:HasLevel() and #rg>0
		and aux.SelectUnselectGroup(rg,e,tp,1,#rg,s.rescon,0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,1,#rg,s.rescon,1,tp,HINTMSG_REMOVE,s.rescon)
	e:SetLabel(g:GetSum(Card.GetLevel)+c:GetLevel())
	Duel.Remove(g+c,POS_FACEUP,REASON_COST)
end
function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.gyspfilter(chkc,e,tp,e:GetLabel()) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.gyspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.gyspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	tc:AssumeProperty(ASSUME_TYPE,tc:GetType()|TYPE_TUNER)
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--It is treated as a Tuner
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end