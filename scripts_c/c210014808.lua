--Melodious Concert Stage
--designed and scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x9b)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--search
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(440556,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCountLimit(1,id0)
	e6:SetCondition(s.spcon)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
end
s.listed_names={0x9b,id}
function s.cfilter(c,tp)
	return c:IsPreviousSetCard(0x9b) and (c:GetPreviousTypeOnField()&TYPE_MONSTER)>0
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
		and c:GetSummonLocation()==LOCATION_EXTRA and c:GetPreviousControler()==tp
		and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()~=tp
end
function s.spfilter2(c,tc)
	return c:GetCode()==tc:GetCode()
end
function s.spfilter(c,e,tp,eg)
	return c:IsSetCard(0x9b) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,tp,0,false,false)
		and not eg:IsExists(s.spfilter2,1,nil,c)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chck:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,eg) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
------------------------------------------------------------
function s.thfilter(c)
	return (c:IsCode(9113513,11493868,44256816,63804637) or aux.IsCodeListed(c,0x9b) or c:IsSetCard(0x9b)) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		local sg=Group.CreateGroup()
		while #sg<3 do
			local cg=g
			if #sg>0 then
				for sc in aux.Next(sg) do
					cg=cg:Filter(aux.NOT(Card.IsCode),nil,sc:GetCode())
				end
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tc=cg:SelectUnselect(sg,tp,false,false,1,3)
			if not tc then break end
			if not sg:IsContains(tc) then
				sg:AddCard(tc)
			else
				sg:RemoveCard(tc)
			end
		end
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1)
		local tc=tg:GetFirst()
		if tc:IsAbleToHand() then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			sg:RemoveCard(tc)
		end
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end