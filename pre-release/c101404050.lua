--ネオ・カオス・フォーム
--Neo Chaos Form
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects (but you can only use each effect of "Neo Chaos Form" once per turn);
	--● Fusion Summon 1 "Blue-Eyes" Fusion Monster from your Extra Deck, by shuffling its materials from your hand, GY, and/or banishment into the Deck.
	--● Ritual Summon 1 "Chaos" or "Black Luster Soldier" Ritual Monster from your hand or banishment, by banishing monsters that are "Blue-Eyes White Dragon" and/or mention "Endless Darkness" from your hand, field, and/or GY whose total Levels equal or exceed its Level.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON,CARD_ENDLESS_DARKNESS}
s.listed_series={SET_BLUE_EYES,SET_CHAOS}
local fusion_params={
	fusfilter=function(c)
		return c:IsSetCard(SET_BLUE_EYES)
	end,
	matfilter=aux.FALSE,
	extrafil=function(e,tp,mg,sumtype)
		return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsAbleToDeck)),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	end,
	extraop=Fusion.ShuffleMaterial
}
local ritual_params={
	lvtype=RITPROC_GREATER,
	filter=function(c)
		return c:IsSetCard(SET_CHAOS) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
	end,
	location=LOCATION_HAND|LOCATION_REMOVED,
	matfilter=function(c)
		return (c:IsCode(CARD_BLUEEYES_W_DRAGON) or c:ListsCode(CARD_ENDLESS_DARKNESS)) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:HasLevel() and c:IsAbleToRemove()
	end,
	extrafil=function(e,tp,eg,ep,ev,re,r,rp,chk)
		return Duel.GetMatchingGroup(nil,tp,LOCATION_GRAVE,0,nil)
	end,
	extratg=function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE)
	end,
	extraop=function(mat,e,tp,eg,ep,ev,re,r,rp,tc)
		Duel.Remove(mat,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
	end
}
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	--● Fusion Summon 1 "Blue-Eyes" Fusion Monster from your Extra Deck, by shuffling its materials from your hand, GY, and/or banishment into the Deck.
	local option_1=not Duel.HasFlagEffect(tp,id)
		and Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
	--● Ritual Summon 1 "Chaos" or "Black Luster Soldier" Ritual Monster from your hand or banishment, by banishing monsters that are "Blue-Eyes White Dragon" and/or mention "Endless Darkness" from your hand, field, and/or GY whose total Levels equal or exceed its Level.
	local option_2=not Duel.HasFlagEffect(tp,id+100)
		and Ritual.Target(ritual_params)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return option_1 or option_2 end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cost_skip=e:GetLabel()~=-100
	--● Fusion Summon 1 "Blue-Eyes" Fusion Monster from your Extra Deck, by shuffling its materials from your hand, GY, and/or banishment into the Deck.
	local option_1=(cost_skip or not Duel.HasFlagEffect(tp,id))
		and Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
	--● Ritual Summon 1 "Chaos" or "Black Luster Soldier" Ritual Monster from your hand or banishment, by banishing monsters that are "Blue-Eyes White Dragon" and/or mention "Endless Darkness" from your hand, field, and/or GY whose total Levels equal or exceed its Level.
	local option_2=(cost_skip or not Duel.HasFlagEffect(tp,id+100))
		and Ritual.Target(ritual_params)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then e:SetLabel(0) return option_1 or option_2 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,1)},
		{option_2,aux.Stringid(id,2)})
	e:GetChainData().choice=choice
	if choice==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
	elseif choice==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● Fusion Summon 1 "Blue-Eyes" Fusion Monster from your Extra Deck, by shuffling its materials from your hand, GY, and/or banishment into the Deck.
		Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
	elseif choice==2 then
		--● Ritual Summon 1 "Chaos" or "Black Luster Soldier" Ritual Monster from your hand or banishment, by banishing monsters that are "Blue-Eyes White Dragon" and/or mention "Endless Darkness" from your hand, field, and/or GY whose total Levels equal or exceed its Level.
		Ritual.Operation(ritual_params)(e,tp,eg,ep,ev,re,r,rp)
	end
end