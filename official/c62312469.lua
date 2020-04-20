--ダーク・ドリアード
--Dark Doriado
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--deck sort
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(s.sttg)
	e4:SetOperation(s.stop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
function s.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND)
end
function s.value(e,c)
	local tp=e:GetHandlerPlayer()
	local att=0
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		att=(att|tc:GetAttribute())
	end
	local ct=0
	while att~=0 do
		if (att&0x1)~=0 then ct=ct+1 end
		att=(att>>1)
	end
	return ct*200
end
function s.spfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsAttribute(ATTRIBUTE_EARTH) or c:IsAttribute(ATTRIBUTE_WATER)
				or c:IsAttribute(ATTRIBUTE_FIRE) or  c:IsAttribute(ATTRIBUTE_WIND))
end
function s.get_series(c)
	local res={}
	if c:IsAttribute(ATTRIBUTE_EARTH) then table.insert(res,1) end
	if c:IsAttribute(ATTRIBUTE_WATER) then table.insert(res,2) end
	if c:IsAttribute(ATTRIBUTE_FIRE)  then table.insert(res,4) end
	if c:IsAttribute(ATTRIBUTE_WIND)  then table.insert(res,8) end
	return res
end
function s.rescon(c,sg,arch_tab)
	local arch_lst=s.get_series(c)
	for _,ar in ipairs(arch_lst) do
		for __,chk in ipairs(arch_tab) do
			if (ar&chk)==0 then
				return true
			end
		end
	end
	return false
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>=4 and g:IsExists(s.rescon,1,nil,Group.CreateGroup(),{0}) end
end
function update_table(global_table,c)
	local tmp_table={}
	local arch_lst=s.get_series(c)
	for _,ar in ipairs(arch_lst) do
		for __,chk in ipairs(global_table) do
			if (ar&chk)==0 then
				table.insert(tmp_table,ar|chk)
			end
		end
	end
	return tmp_table
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil)
	if #g>=4 and g:IsExists(s.rescon,1,nil,Group.CreateGroup(),{0}) then
		local sg=Group.CreateGroup()
		local arch_tab={0}
		while #sg<4 do
			local mg=g:Filter(s.rescon,sg,sg,arch_tab)
			if #mg==0 then break end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
			local tc=mg:SelectUnselect(sg,tp,false,false,4,4)
			if not tc then break end
			if sg:IsContains(tc) then
				sg:RemoveCard(tc)
				arch_tab={0}
				for card in aux.Next(sg) do
					arch_tab=update_table(arch_tab,card)
				end
			else
				sg:AddCard(tc)
				arch_tab=update_table(arch_tab,tc)
			end		
		end
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		Duel.MoveToDeckTop(sg)
		Duel.SortDecktop(tp,tp,4)
	end
end
