--サプライズ・フュージョン
--Surprise Fusion
--scripted by pyrQ
local s,id=GetID()
local TOKEN_SURPRISE=id+100
function s.initial_effect(c)
	--Make 1 face-up monster you control become the declared Type and Attribute, then you can Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters you control, including the targeted monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Tribute 1 Fusion Monster, and if you do, Special Summon 2 "Surprise Tokens" (Spellcaster/DARK/ATK 0/DEF 0) with a Level equal to the Level the Tributed monster had on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tokentg)
	e2:SetOperation(s.tokenop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_SURPRISE}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local race=Duel.AnnounceRace(tp,1,RACE_ALL)
	local attr=tc:IsRaceExcept(race) and Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL) or tc:AnnounceAnotherAttribute(tp)
	e:SetLabel(race,attr)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local c=e:GetHandler()
		local race,attr=e:GetLabel()
		if tc:IsRaceExcept(race) then
			--It becomes that Type
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(race)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		if tc:IsAttributeExcept(attr) then
			--It becomes that Attribute
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e2:SetValue(attr)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		if not (tc:IsRace(race) or tc:IsAttribute(attr)) then return end
		local fusion_params={matfilter=Fusion.OnFieldMat,gc=tc}
		if Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function s.tributefilter(c,tp)
	return c:IsFusionMonster() and c:IsReleasableByEffect() and Duel.GetMZoneCount(tp,c)>=2
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SURPRISE,0,TYPES_TOKEN,0,0,c:GetLevel(),RACE_SPELLCASTER,ATTRIBUTE_DARK)
end
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.CheckReleaseGroup(tp,s.tributefilter,1,false,1,true,nil,tp,nil,false,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local sc=Duel.SelectReleaseGroup(tp,s.tributefilter,1,1,false,false,true,nil,tp,nil,false,nil,tp):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	local lv=sc:GetLevel()
	if Duel.Release(sc,REASON_EFFECT)>0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SURPRISE,0,TYPES_TOKEN,0,0,lv,RACE_SPELLCASTER,ATTRIBUTE_DARK) then
		for i=1,2 do
			local token=Duel.CreateToken(tp,TOKEN_SURPRISE)
			token:Level(lv)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	end
end