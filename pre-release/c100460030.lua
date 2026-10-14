--海晶乙女トゥルースハート
--Marincess Truth Heart
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ "Marincess" monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_MARINCESS),2)
	--If this card is Link Summoned using a Link Monster with 0 original ATK: You can Special Summon 1 Link-3 or lower "Marincess" monster from your Extra Deck. You can only use this effect of "Marincess Truth Heart" once per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(function(e,c)
		local material_chk=c:GetMaterial():IsExists(aux.AND(Card.IsLinkMonster,Card.IsBaseAttack),1,nil,0)
		e:SetLabel(material_chk and 1 or 0)
	end)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsLinkSummoned() and e0:GetLabel()==1
	end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--You can banish 1 Link Monster Card from your field or GY; destroy 1 card your opponent controls, also for the rest of this turn, you cannot banish monsters with that same Link Rating to activate this effect of "Marincess Truth Heart"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Keep track of the Link Ratings of the monsters banished as cost
	aux.GlobalCheck(s,function()
		s.link_rating_list={}
		s.link_rating_list[0]={}
		s.link_rating_list[1]={}
		aux.AddValuesReset(function()
			s.link_rating_list[0]={}
			s.link_rating_list[1]={}
		end)
	end)
end
s.listed_series={SET_MARINCESS}
s.material_setcode={SET_MARINCESS}
s.listed_names={id}
function s.spfilter(c,e,tp)
	return c:IsLinkBelow(3) and c:IsSetCard(SET_MARINCESS) and c:IsLinkMonster() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.descostfilter(c,tp)
	return c:IsOriginalType(TYPE_LINK) and c:IsMonsterCard() and c:IsFaceup() and c:IsAbleToRemoveAsCost() and not s.link_rating_list[tp][c:GetLink()]
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=Duel.SelectMatchingCard(tp,s.descostfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	Duel.Remove(sc,POS_FACEUP,REASON_COST)
	e:GetChainData().link_rating=sc:GetLink()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local link_rating=e:GetChainData().link_rating
	s.link_rating_list[tp][link_rating]=true
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end