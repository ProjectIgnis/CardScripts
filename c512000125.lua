--強欲な壺
--Pot
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local num=Duel.GetRandomNumber(1,20)
	if num==1 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(3)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	elseif num==2 or num==20 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		e:SetProperty(0)
		local ct=num==2 and 3 or 1
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,0)
	elseif num==3 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,0)
	elseif num==4 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	elseif num==5 or num==14 or num==17 or num==18 then
		e:SetCategory(0)
		e:SetProperty(0)
	elseif num==6 or num==7 then
		e:SetCategory(CATEGORY_HANDES)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		Duel.SetTargetParam(1)
		local p=num==6 and tp or 1-tp
		Duel.SetTargetPlayer(p)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,p,1)
	elseif num==8 or num==9 then
		e:SetCategory(CATEGORY_RECOVER)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		if num==8 then
			Duel.SetTargetPlayer(tp)
			Duel.SetTargetParam(2000)
			Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
		else
			Duel.SetTargetPlayer(1-tp)
			Duel.SetTargetParam(5000)
			Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,5000)
		end
	elseif num==10 or num==11 or num==12 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(0)
		local s,o
		if num==10 then
			s,o=LOCATION_MZONE,LOCATION_MZONE
		elseif num==11 then
			s,o=0,LOCATION_MZONE
		else
			s,o=LOCATION_MZONE,LOCATION_SZONE
		end
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,s,o,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	elseif num==13 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(0)
		local sg=Group.CreateGroup()
		for i=1,10 do
			local token=Duel.CreateToken(i%2,35261759)
			sg:AddCard(token)
		end
		Duel.Remove(sg,POS_FACEDOWN,REASON_COST)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	elseif num==14 then
		e:SetCategory(CATEGORY_TOGRAVE)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
	elseif num==15 then
		e:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		local g=Duel.GetDecktopGroup(1-tp,1)
		local tc=Duel.GetFieldCard(1-tp,LOCATION_DECK,1)
		g:AddCard(tc)
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	elseif num==16 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		Duel.SetTargetPlayer(tp)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)
		local tc1=Duel.GetFieldCard(tp,LOCATION_GRAVE,ct-1)
		local tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,ct-2)
		if tc1 and tc2 then
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,Group.FromCards(tc1,tc2),2,0,0)
		end
	elseif num==19 then
		e:SetCategory(CATEGORY_DAMAGE)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		local p=Duel.GetRandomNumber(1)
		local dam=Duel.GetRandomNumber(1,2300)
		Duel.SetTargetPlayer(p)
		Duel.SetTargetParam(dam)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,dam)
	end
	e:SetLabel(num)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local num=e:GetLabel()
	if num==1 or num==4 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	elseif num==2 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<3 
			or not Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) then return end
		for i=1,3 do
			local token=Duel.CreateToken(tp,29843091+i)
			if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UNRELEASABLE_SUM)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(1)
				token:RegisterEffect(e1,true)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_LEAVE_FIELD)
				e2:SetOperation(s.damop)
				token:RegisterEffect(e2,true)
			end
		end
		Duel.SpecialSummonComplete()
	elseif num==3 then
		local token=Duel.CreateToken(1-tp,55144522)
		Duel.SendtoHand(token,1-tp,REASON_EFFECT)
		Duel.ConfirmCards(tp,token)
	elseif num==5 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCode(EFFECT_SKIP_M1)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		Duel.RegisterEffect(e1,tp)
	elseif num==6 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		if #g>0 then
			local sg=g:RandomSelect(p,d)
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		end
	elseif num==7 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DISCARD)
			local sg=g:Select(p,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		end
	elseif num==8 or num==9 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Recover(p,d,REASON_EFFECT)
	elseif num==10 or num==11 or num==12 then
		if num==10 then
			s,o=LOCATION_MZONE,LOCATION_MZONE
		elseif num==11 then
			s,o=0,LOCATION_MZONE
		else
			s,o=LOCATION_MZONE,LOCATION_SZONE
		end
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,s,o,nil)
		Duel.Destroy(sg,REASON_EFFECT)
	elseif num==13 then
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.Draw(1-tp,1,REASON_EFFECT)
	elseif num==14 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_DECK,0,nil):RandomSelect(tp,2)
		Duel.SendtoGrave(g,REASON_EFFECT)
	elseif num==15 then
		local g=Duel.GetDecktopGroup(1-tp,1)
		local tc=Duel.GetFieldCard(1-tp,LOCATION_DECK,1)
		g:AddCard(tc)
		Duel.SendtoGrave(g,REASON_EFFECT)
	elseif num==16 then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
		if #g>=2 then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
			local sg=g:Select(p,2,2,nil)
			Duel.ConfirmCards(1-p,sg)
			if Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)>0 then
				Duel.ShuffleDeck(p)
				Duel.BreakEffect()
				local ct=Duel.GetFieldGroupCount(p,LOCATION_GRAVE,0)
				local tc1=Duel.GetFieldCard(p,LOCATION_GRAVE,ct-1)
				local tc2=Duel.GetFieldCard(p,LOCATION_GRAVE,ct-2)
				if tc1 and tc2 then
					Duel.SendtoHand(Group.FromCards(tc1,tc2),nil,REASON_EFFECT)
					Duel.ConfirmCards(1-p,tc)
				end
			end
		end
	elseif num==17 then
		local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #g1>0 and #g2>0 then
			Duel.ConfirmCards(tp,g2)
			Duel.ConfirmCards(1-tp,g1)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local ag1=g2:Select(tp,2,2,nil)
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
			local ag2=g1:Select(1-tp,2,2,nil)
			Duel.SendtoHand(ag1,tp,REASON_EFFECT)
			Duel.SendtoHand(ag2,1-tp,REASON_EFFECT)
		end
	elseif num==18 then
		Duel.SetLP(tp,Duel.GetLP(tp)*2,REASON_EFFECT)
	elseif num==19 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	elseif num==20 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,24874631,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK) then
			local token=Duel.CreateToken(tp,24874631)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetOperation(s.damop2)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e2,true)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetRange(LOCATION_MZONE)
			e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e3:SetCountLimit(1)
			e3:SetCondition(s.descon)
			e3:SetOperation(s.desop)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e3,true)
		end
	else
		local lp=Duel.GetLP(tp)+Duel.GetLP(1-tp)
		Duel.SetLP(tp,lp)
		Duel.SetLP(1-tp,lp)
	end
	
	--
	local c=e:GetHandler()
	local maxran=Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 and 5 or 4
	local res=Duel.GetRandomNumber(1,maxran)
	c:CancelToGrave(true)
	if res==1 then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	elseif res==2 then
		Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
	elseif res==3 then
		Duel.SendtoHand(c,1-tp,REASON_EFFECT)
		Duel.ConfirmCards(tp,c)
	elseif res==4 then
		Duel.SendtoDeck(c,1-tp,2,REASON_EFFECT)
	else
		Duel.MoveToField(c,tp,1-tp,LOCATION_SZONE,POS_FACEDOWN,false)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		Duel.Damage(c:GetPreviousControler(),300,REASON_EFFECT)
	end
	e:Reset()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(tp,1000) and Duel.SelectYesNo(tp,aux.Stringid(1040,7)) then
		Duel.PayLPCost(tp,1000)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetBattleDamage(tp)
	if dam>0 then
		Duel.ChangeBattleDamage(1-tp,Duel.GetBattleDamage(1-tp)+dam,false)
		Duel.ChangeBattleDamage(tp,0)
	end
end
