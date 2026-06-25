--ぜんなのついなぎひめ
--Zenna-no-Tsuinagihime
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ Effect Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
	--You can also use 1 monster in your hand as material to Link Summon this card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(1,0)
	e0:SetOperation(function(c,e,tp,sg,mg,lc,og,chk) return sg:FilterCount(Card.HasFlagEffect,nil,id)<=1 end)
	e0:SetValue(s.extraval)
	c:RegisterEffect(e0)
	--If this card is Link Summoned: You can send 1 monster from your Deck to the GY, or if this card was Link Summoned using only monsters you control, you can send 1 monster from your Extra Deck to the GY instead
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOGRAVE)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1a:SetTarget(s.tgtg)
	e1a:SetOperation(s.tgop)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_MATERIAL_CHECK)
	e1b:SetValue(s.matcheck)
	e1b:SetLabelObject(e1a)
	c:RegisterEffect(e1b)
	--During your next Standby Phase after this card was sent from the field to the GY: You can add 1 monster from your GY to your hand
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOHAND)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2a:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2a:SetRange(LOCATION_GRAVE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCondition(function(e,tp) local c=e:GetHandler() return Duel.IsTurnPlayer(tp) and c:HasFlagEffect(id) and (c:GetFlagEffectLabel(id)==1 or c:GetTurnID()~=Duel.GetTurnCount()) end)
	e2a:SetTarget(s.thtg)
	e2a:SetOperation(s.thop)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2b:SetCode(EVENT_TO_GRAVE)
	e2b:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e2b:SetOperation(function(e,tp) local ct=(Duel.IsTurnPlayer(tp) and Duel.IsPhase(PHASE_STANDBY)) and 2 or 1 e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,0,ct,ct) end)
	c:RegisterEffect(e2b)
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			local g=Duel.GetMatchingGroup(aux.NOT(Card.HasFlagEffect),tp,LOCATION_HAND,0,nil,id)
			for mc in g:Iter() do
				mc:RegisterFlagEffect(id,0,0,1)
			end
			return g
		end
	elseif chk==2 then
		local g=Duel.GetMatchingGroup(Card.HasFlagEffect,e:GetHandlerPlayer(),LOCATION_HAND,0,nil,id)
		for mc in g:Iter() do
			mc:ResetFlagEffect(id)
		end
	end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local locations=e:GetLabel()==0 and LOCATION_DECK or LOCATION_DECK|LOCATION_EXTRA
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsMonster,Card.IsAbleToGrave),tp,locations,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,locations)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local locations=e:GetLabel()==0 and LOCATION_DECK or LOCATION_DECK|LOCATION_EXTRA
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsMonster,Card.IsAbleToGrave),tp,locations,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.matcheckfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.matcheck(e,c)
	local mg=c:GetMaterial()
	e:GetLabelObject():SetLabel(mg:FilterCount(s.matcheckfilter,nil,e:GetHandlerPlayer())==#mg and 1 or 0)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsMonster,Card.IsAbleToHand),tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsMonster,Card.IsAbleToHand),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end