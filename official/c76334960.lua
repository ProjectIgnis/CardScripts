--召喚魔術－「杯」
--Invocation - "Chalice"
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If you have an "Aleister" monster in your field, GY, or banishment: Activate 1 of these effects;
	--● Fusion Summon 1 "Invoked" Fusion Monster from your Extra Deck, by banishing 1 monster from your hand or field and 1 monster from your Deck
	local fusion_params1={
		fusfilter=function(c)
			return c:IsSetCard(SET_INVOKED)
		end,
		exactcount=2,
		matfilter=Card.IsAbleToRemove,
		extrafil=function(e,tp,mg)
			return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_DECK,0,nil),
				function(tp,sg,fc)
					return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==1
				end
		end,
		extratg=function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then return true end
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_DECK)
		end,
		extraop=Fusion.BanishMaterial
	}
	local fustg1=Fusion.SummonEffTG(fusion_params1)
	local fusop1=Fusion.SummonEffOP(fusion_params1)
	--● Fusion Summon 1 "Invoked" Fusion Monster from your Extra Deck, by banishing 1 monster you control and 1 face-up monster your opponent controls
	local fusion_params2={
		fusfilter=function(c)
			return c:IsSetCard(SET_INVOKED)
		end,
		exactcount=2,
		matfilter=Fusion.OnFieldMat(Card.IsAbleToRemove),
		extrafil=function(e,tp,mg)
			return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(aux.FaceupFilter(Card.IsAbleToRemove)),tp,0,LOCATION_ONFIELD,nil),
				function(tp,sg,fc)
					return sg:FilterCount(Card.IsControler,nil,1-tp)==1
				end
		end,
		extratg=function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then return true end
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,PLAYER_ALL,LOCATION_ONFIELD)
		end,
		extraop=Fusion.BanishMaterial
	}
	local fustg2=Fusion.SummonEffTG(fusion_params2)
	local fusop2=Fusion.SummonEffOP(fusion_params2)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target(fustg1,fustg2))
	e1:SetOperation(s.activate(fusop1,fusop2))
	c:RegisterEffect(e1)
end
s.listed_seriess={SET_ALEISTER,SET_INVOKED}
function s.confilter(c)
	return c:IsSetCard(SET_ALEISTER) and c:IsMonster() and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
end
function s.target(fustg1,fustg2)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local b1=fustg1(e,tp,eg,ep,ev,re,r,rp,0)
		local b2=fustg2(e,tp,eg,ep,ev,re,r,rp,0)
		if chk==0 then return b1 or b2 end
		local cd=e:GetChainData()
		cd.choice=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
		if cd.choice==1 then
			fustg1(e,tp,eg,ep,ev,re,r,rp,1)
		elseif cd.choice==2 then
			fustg2(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
end
function s.activate(fusop1,fusop2)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local cd=e:GetChainData()
		if cd.choice==1 then
			--● Fusion Summon 1 "Invoked" Fusion Monster from your Extra Deck, by banishing 1 monster from your hand or field and 1 monster from your Deck
			fusop1(e,tp,eg,ep,ev,re,r,rp)
		elseif cd.choice==2 then
			--● Fusion Summon 1 "Invoked" Fusion Monster from your Extra Deck, by banishing 1 monster you control and 1 face-up monster your opponent controls
			fusop2(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end