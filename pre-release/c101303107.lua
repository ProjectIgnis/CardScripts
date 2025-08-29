--ダブル・トリガー
--Double Trigger
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	local fusion_params={
				handler=c,
				matfilter=aux.FALSE,
				extrafil=s.fextra,
				extraop=Fusion.BanishMaterial,
				extratg=s.extratg
			}
	local ritual_params={
				handler=c,
				lvtype=RITPROC_GREATER,
				forcedselection=s.forcedselection,
				matfilter=aux.FilterBoolFunction(Card.IsLocation,LOCATION_GRAVE),
				extrafil=s.rextra,
				extratg=s.extratg
			}
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.effcost(fusion_params,ritual_params))
	e1:SetTarget(s.efftg(fusion_params,ritual_params))
	e1:SetOperation(s.effop(fusion_params,ritual_params))
	c:RegisterEffect(e1)
end
s.listed_series={SET_ROKKET}
function s.matcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_ROKKET,fc,SUMMON_TYPE_FUSION,tp)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil),s.matcheck
	end
	return nil,s.matcheck
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.rextra(e,tp,eg,ep,ev,re,r,rp,chk)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(aux.AND(Card.HasLevel,Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
end
function s.forcedselection(e,tp,sg,sc)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_ROKKET)
end
function s.effcost(fusion_params,ritual_params)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		e:SetLabel(-100)
		local b1=not Duel.HasFlagEffect(tp,id)
			and Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
		local b2=not Duel.HasFlagEffect(tp,id+100)
			and Ritual.Target(ritual_params)(e,tp,eg,ep,ev,re,r,rp,0)
		if chk==0 then return b1 or b2 end
	end
end
function s.efftg(fusion_params,ritual_params)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local cost_skip=e:GetLabel()~=-100
		local b1=(cost_skip or not Duel.HasFlagEffect(tp,id))
			and Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
		local b2=(cost_skip or not Duel.HasFlagEffect(tp,id+100))
			and Ritual.Target(ritual_params)(e,tp,eg,ep,ev,re,r,rp,0)
		if chk==0 then e:SetLabel(0) return b1 or b2 end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
		e:SetLabel(op)
		if op==1 then
			e:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
			if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
			Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,1)
		elseif op==2 then
			e:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
			if not cost_skip then Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1) end
			Ritual.Target(ritual_params)(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
end
function s.effop(fusion_params,ritual_params)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local op=e:GetLabel()
		if op==1 then
			--Fusion Summon 1 Fusion Monster from your Extra Deck, by banishing its materials from your GY, including a "Rokket" monster
			Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
		elseif op==2 then
			--Ritual Summon 1 Ritual Monster from your hand, by banishing monsters from your GY whose total Levels equal or exceed that monster's Level, including a "Rokket" monster
			Ritual.Operation(ritual_params)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end