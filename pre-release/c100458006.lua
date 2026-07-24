--光帰葬魂の儀
--Beresennet Em Heru
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Once per turn: You can Ritual Summon 1 "Sennet" Ritual Monster from your hand or GY, by sending Normal Monster Cards with different names from each other from your hand, Deck, and/or face-up field to the GY whose total Levels equal or exceed its Level, then you can equip 1 Normal Monster from your GY to it as an Equip Spell
	local ritual_params={
		lvtype=RITPROC_GREATER,
		filter=function(c)
			return c:IsSetCard(SET_SENNET)
		end,
		location=LOCATION_HAND|LOCATION_GRAVE,
		matfilter=function(c)
			return c:IsOriginalType(TYPE_NORMAL) and (c:IsFaceup() or not c:IsOnField()) and c:IsAbleToGrave()
		end,
		extratg=function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then return true end
			Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD)
			Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
		end,
		extraop=function(mg,e,tp,eg,ep,ev,re,r,rp)
			Duel.SendtoGrave(mg,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
		end,
		extrafil=function(e,tp,mg)
			return Duel.GetMatchingGroup(Card.IsOriginalType,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD,0,nil,TYPE_NORMAL)
		end,
		forcedselection=function(e,tp,sg,ritc)
			return sg:GetClassCount(Card.GetCode)==#sg
		end,
		stage2=function(mg,e,tp,eg,ep,ev,re,r,rp,ritc)
			if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
				and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,nil,tp)
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local eqc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
				if not eqc then return end
				Duel.BreakEffect()
				if Duel.Equip(tp,eqc,ritc) then
					--Equip limit
					local e0=Effect.CreateEffect(e:GetHandler())
					e0:SetType(EFFECT_TYPE_SINGLE)
					e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e0:SetCode(EFFECT_EQUIP_LIMIT)
					e0:SetValue(function(e,c) return c==ritc end)
					e0:SetReset(RESET_EVENT|RESETS_STANDARD)
					eqc:RegisterEffect(e0)
				end
			end
		end
	}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(Ritual.Target(ritual_params))
	e1:SetOperation(Ritual.Operation(ritual_params))
	c:RegisterEffect(e1)
	--If you Special Summon a non-Token Normal Monster(s): You can draw 1 card. You can only use this effect of "Beresennet Em Heru" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SENNET}
function s.eqfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.drconfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and not c:IsType(TYPE_TOKEN) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drconfilter,1,nil,tp)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end