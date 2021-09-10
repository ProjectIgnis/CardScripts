--漆黒シャイン王Gアークトーク 
--Shining Black Corporate King Great Arktalk the Corrupt

local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160006024,160204039)
	--Gain 200 ATK per machine in your GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,600) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,e:GetHandler(),RACE_MACHINE) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.PayLPCost(tp,600)>0 then
		--Effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			local atk=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,e:GetHandler(),RACE_MACHINE)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			e1:SetValue(atk*200)
			c:RegisterEffect(e1)
			local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,tp)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
				if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)~0 then
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
	end
end
function s.tdfilter(c,tp)
	return c:IsCode(160006062,160006063) and c:IsAbleToDeckAsCost()
end