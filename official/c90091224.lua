--四天の龍 ダーク・リベリオン・エクシーズ・ドラゴン
--Dark Rebellion Xyz Dragon of the Four Heavenly Dragons
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 DARK monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
	--If this card is Special Summoned: You can target an equal number of cards on each field; destroy them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--When your opponent activates a card or effect (Quick Effect): You can detach 1 material from this card; Special Summon 1 Rank 4 DARK Xyz Monster from your Extra Deck, using this card you control (this is treated as an Xyz Summon, transfer this card's materials)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp end)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_THE_PHANTOM_KNIGHTS}
function s.desrescon(maxc)
	return function(sg,e,tp,mg)
		local ct1=sg:FilterCount(Card.IsControler,nil,tp)
		local ct2=#sg-ct1
		return ct1==ct2,ct1>maxc or ct2>maxc
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetTargetGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=g:FilterCount(Card.IsControler,nil,tp)
	local rescon=s.desrescon(math.min(ct,#g-ct))
	local tg=aux.SelectUnselectGroup(g,e,tp,2,#g,rescon,1,tp,HINTMSG_DESTROY,rescon)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
function s.spfilter(c,e,tp,mc)
	return c:IsRank(4) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsXyzMonster() and mc:IsCanBeXyzMaterial(c,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		return (#pg<=0 or (#pg==1 and pg:IsContains(c)))
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		if not ((#pg<=0 or (#pg==1 and pg:IsContains(c)))) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c):GetFirst()
		if xyz then
			xyz:SetMaterial(c)
			Duel.Overlay(xyz,c)
			if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
				xyz:CompleteProcedure()
			end
		end
	end
end