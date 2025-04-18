--アロマブレンド
--Aroma Blend
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 "Humid Winds/Dried Winds/Blessed Winds" face-up in the Spell/Trap Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.plcost)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--Fusion Summon 1 Plant Fusion Monster
	local params={handler=c,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_PLANT),
				matfilter=Card.IsAbleToRemove,extrafil=s.extrafil,
				extraop=Fusion.BanishMaterial,extratg=s.extratg}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(Fusion.SummonEffTG(params))
	e2:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e2)
end
s.listed_names={28265983,92266279,15177750} --Humid Winds, Dried Winds, Blessed Winds
function s.cfilter(c,tp)
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,c,tp)
end
function s.plfilter(c,tp)
	return c:IsCode(28265983,92266279,15177750) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),tp) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST|REASON_DISCARD,nil,tp)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,nil,tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
function s.exfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemove()
end
function s.extrafil(e,tp,mg)
	if Duel.GetLP(tp)>Duel.GetLP(1-tp) and not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end